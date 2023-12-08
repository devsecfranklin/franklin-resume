import React from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';

function Login({ setAuth, isAuthenticated }) {
  const history = useHistory();
  if (isAuthenticated) {
    history.push('./');
  }
  const onClickDemo = async () => {
    try {
      const { data: { token, name } } = await axios.post(`${process.env.REACT_APP_API_URL}/login`, {
        email: 'alice@gmail.com',
        password: '123123',
      });
      localStorage.setItem('token', token);
      localStorage.setItem('name', name);
      setAuth(true);
    } catch (err) {
      console.log('Error:', err);
    }
  };
  return (
    <div className="container my-5 text-white login-form d-flex flex-row justify-content-center">
      <form className="form-signin" style={{ width: '400px' }}>
        <h1 className="h3 mb-3 font-weight-bold">Sign In</h1>
        <label htmlFor="inputEmail" className="sr-only my-3">
          Email address
          <input
            type="email"
            id="inputEmail"
            className="form-control"
            placeholder="Email address"
            required
            autoFocus
          />
        </label>
        <label htmlFor="inputPassword" className="sr-only my-3">
          Password
          <input
            type="password"
            id="inputPassword"
            className="form-control"
            placeholder="Password"
            required
          />
        </label>
        <div className="checkbox my-3">
          <label htmlFor="remember-me">
            <input id="remember-me" type="checkbox" value="remember-me" />
            {' '}
            Remember me
          </label>
        </div>
        <button className="btn btn-lg btn-primary btn-block" type="submit">
          Sign in
        </button>
        <br />
        <br />
        <button className="btn btn-lg btn-success btn-block" type="button" onClick={onClickDemo}>
          Demo
        </button>
        <p className="mt-5 mb-3 text-muted">&copy; 2022</p>
      </form>
    </div>
  );
}

export default Login;
