import React, { useContext } from 'react';
import { Redirect } from 'react-router-dom';
import { AuthContext } from '../helpers/auth';

const Logout = () => {
    const auth = useContext(AuthContext);
    auth.handleLogout();

    return <Redirect to="/" />;
};

export default Logout;