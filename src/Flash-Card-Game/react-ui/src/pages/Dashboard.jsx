import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';

function Dashboard({ isAuthenticated }) {
  const history = useHistory();
  if (!isAuthenticated) {
    history.push('./');
  }
  const [user, setUser] = useState([]);
  useEffect(async () => {
    const { data } = await axios.get(`${process.env.REACT_APP_API_URL}/high-scores`);
    const dashboardUser = data.find((ele) => localStorage.getItem('name') === ele.name);
    setUser(dashboardUser);
  }, []);
  return (
    <div className="text-white">
      <div>
        Welcome&nbsp;
        {user.name}

      </div>
      <div>
        Your&nbsp;
        <img width="30" src="./star.png" alt="" />
        &nbsp;score is :&nbsp;
        {user.stars}
      </div>
    </div>
  );
}

export default Dashboard;
