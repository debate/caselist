import express from 'express';
import helmet from 'helmet';
import rateLimiter from 'express-rate-limit';
import uuid from 'uuid/v4';
import expressWinston from 'express-winston';
import bodyParser from 'body-parser';
import cookieParser from 'cookie-parser';
import { initialize } from 'express-openapi';
import path from 'path';
import config from './config';
import apiDoc from './v1/routes/api-doc';
import paths from './v1/routes/paths';
import errorHandler from './v1/helpers/error';
import auth from './v1/helpers/auth';
import { debugLogger, requestLogger, errorLogger } from './v1/helpers/logger';

const app = express();

// Startup log message
debugLogger.info('Initializing API...');

// Enable Helmet security
app.use(helmet());

// Enable getting forwarded client IP from proxy
app.enable('trust proxy');

// Rate limit all requests
const limiter = rateLimiter({
    windowMs: config.RATE_WINDOW || 15 * 60 * 1000, // 15 minutes
    max: config.RATE_MAX || 100000, // limit each IP to 100000 requests per windowMs
    delayMs: config.RATE_DELAY || 0, // disable delaying - full speed until the max limit is reached
});
app.use(limiter);

// Enable CORS
app.use((req, res, next) => {
    // Can't use wildcard for CORS with credentials, so echo back the requesting domain
    const allowedOrigin = req.get('Origin') || '*';
    res.header('Access-Control-Allow-Origin', allowedOrigin);
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    res.header('Access-Control-Expose-Headers', 'Content-Disposition');
    next();
});

// Add a unique UUID to every request
app.use((req, res, next) => {
    req.uuid = uuid();
    return next();
});

// Log all requests
app.use(expressWinston.logger({
    winstonInstance: requestLogger,
    meta: true,
    dynamicMeta: (req, res) => {
        return {
            logCorrelationId: req.uuid,
        };
    },
}));

// Parse body
app.use(bodyParser.json({ type: ['json', 'application/*json'], limit: '10mb' }));
app.use(bodyParser.text({ type: '*/*', limit: '10mb' }));

// Parse cookies as a fallback to basic auth
app.use(cookieParser());

// Initialize OpenAPI middleware
initialize({
    app,
    apiDoc,
    paths,
    docsPath: '/docs',
    promiseMode: true,
    errorMiddleware: errorHandler,
    securityHandlers: {
        cookie: auth,
    },
});

// Log global errors with Winston
app.use(expressWinston.errorLogger({
    winstonInstance: errorLogger,
    meta: true,
    dynamicMeta: (req, res) => {
        return {
            logCorrelationId: req.uuid,
        };
    },
}));

app.use(express.static(path.join(__dirname, '../client/build')));
app.get('/', (req, res) => {
    return res.sendFile(path.join(`${__dirname}/client/build/index.html`));
});

// Final fallback error handling
app.use(errorHandler);

// Start server
const port = process.env.PORT || config.PORT || 10010;
app.listen(port, () => {
    debugLogger.info(`Server started. Listening on port ${port}`);
});

export default app;
