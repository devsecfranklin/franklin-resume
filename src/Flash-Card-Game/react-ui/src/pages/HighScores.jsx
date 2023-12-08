import React, { useState, useEffect } from 'react';
import { Table } from 'react-bootstrap';
import axios from 'axios';

function HighScores() {
  const [users, setUsers] = useState([]);
  useEffect(async () => {
    const { data } = await axios.get(`${process.env.REACT_APP_API_URL}/high-scores`);
    setUsers(data);
  }, []);

  return (
    <div className="container">
      <Table striped bordered hover variant="dark">
        <thead>
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>
              Stars&nbsp;
              <img width="30" src="./star.png" alt="" />
            </th>
            <th>
              Gems&nbsp;
              <img width="30" src="./gem.png" alt="" />
            </th>
          </tr>
        </thead>
        <tbody>
          {users.length > 0 && users.map((user, idx) => (
            <tr key={user.name}>
              <td>{idx + 1}</td>
              <td>{user.name}</td>
              <td>{user.stars}</td>
              <td>{user.gems}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
}

export default HighScores;
