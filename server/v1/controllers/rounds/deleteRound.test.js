import { assert } from 'chai';
import SQL from 'sql-template-strings';
import request from 'supertest';
import fs from 'fs';
import { query } from '../../helpers/mysql';
import config from '../../../config';
import server from '../../../index';

describe('DELETE /v1/caselists/{caselist}/schools/{school}/teams/{team}/rounds/{round}', () => {
    beforeEach(async () => {
        await fs.promises.mkdir(`${config.UPLOAD_DIR}`, { recursive: true });
        await fs.promises.writeFile(`${config.UPLOAD_DIR}/test`, 'test');
    });

    it('should delete a round', async () => {
        const newRound = await query(SQL`
            INSERT INTO rounds (team_id, tournament, side, round, opensource) VALUES
                (1, 'Test Tourn', 'A', '1', 'test');
        `);
        await query(SQL`
            INSERT INTO cites (round_id, title, cites) VALUES
                (${newRound.insertId}, 'TestDelete', 'TestDelete');
        `);

        await request(server)
            .delete(`/v1/caselists/testcaselist/schools/testschool/teams/testteam/rounds/${newRound.insertId}`)
            .set('Accept', 'application/json')
            .set('Cookie', ['caselist_token=test'])
            .expect('Content-Type', /json/)
            .expect(200);

        const rounds = await query(SQL`
            SELECT COUNT(*) AS 'count' FROM rounds WHERE round_id = ${newRound.insertId}
        `);
        assert.strictEqual(rounds[0].count, 0, 'Round deleted');

        const cites = await query(SQL`
            SELECT COUNT(*) AS 'count' FROM cites WHERE round_id = ${newRound.insertId}
        `);
        assert.strictEqual(cites[0].count, 0, 'Cite deleted');

        const roundsHistory = await query(SQL`
            SELECT COUNT(*) AS 'count' FROM rounds_history WHERE round_id = ${newRound.insertId}
        `);
        assert.strictEqual(roundsHistory[0].count, 1, 'Round history entry');
        const citesHistory = await query(SQL`
            SELECT COUNT(*) AS 'count' FROM cites_history WHERE round_id = ${newRound.insertId}
        `);
        assert.strictEqual(citesHistory[0].count, 1, 'Cite history entry');

        try {
            await fs.promises.access(`${config.UPLOAD_DIR}/test`, fs.constants.F_OK);
        } catch (err) {
            assert.isOk(err, 'File deleted');
        }
    });

    it('should return a 400 for a non-existing round', async () => {
        await request(server)
            .delete(`/v1/caselists/testcaselist/schools/testschool/teams/testteam/rounds/4`)
            .set('Accept', 'application/json')
            .set('Cookie', ['caselist_token=test'])
            .expect('Content-Type', /json/)
            .expect(400);
    });

    it('should return a 403 for an archived round', async () => {
        await request(server)
            .delete(`/v1/caselists/archivedcaselist/schools/archivedschool/teams/archivedteam/rounds/3`)
            .set('Accept', 'application/json')
            .set('Cookie', ['caselist_token=test'])
            .expect('Content-Type', /json/)
            .expect(403);
    });

    it('should return a 401 with no authorization cookie', async () => {
        await request(server)
            .delete(`/v1/caselists/testcaselist/schools/testschool/teams/testteam/rounds/1`)
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(401);
    });

    afterEach(async () => {
        try {
            await fs.promises.rm(`${config.UPLOAD_DIR}/test`);
        } catch {
            // Do Nothing
        }
        await query(SQL`
            DELETE FROM rounds_history WHERE team_id = 1
        `);
        await query(SQL`
            DELETE FROM cites_history WHERE title = 'TestDelete' and cites = 'TestDelete'
        `);
    });
});