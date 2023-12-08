require('dotenv').config();
const { Model, DataTypes } = require('@sequelize/core');
// const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { promisify } = require('util');

const verify = promisify(jwt.verify);
const { sequelize } = require('../models/index');

const oneMonth = 1000 * 60 * 60 * 24 * 30;

class User extends Model {
  static isCorrectPassword(inputPassword, dbPassword) {
    return inputPassword === dbPassword;
  }
}

User.init(
  {
    name: {
      type: DataTypes.STRING,
      validate: {
        notEmpty: true,
      },
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
    stars: {
      type: DataTypes.INTEGER,
    },
    gems: {
      type: DataTypes.INTEGER,
    },
    lastsignedin: {
      type: 'TIMESTAMP',
    },
    firsttimegems: {
      type: DataTypes.BOOLEAN,
    },
    password: {
      type: DataTypes.STRING,
      validate: {
        notEmpty: true,
      },
    },
  },
  {
    sequelize,
    modelName: 'user',
  },
);

exports.login = async (req, res) => {
  try {
    let { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) throw new Error('User not found');
    // check password
    if (await User.isCorrectPassword(password, user.password)) {
      // console.log('password ok');
      const token = jwt.sign({ id: user.id }, process.env.SECRET, {
        expiresIn: oneMonth,
      });
      res.cookie('token', token, {
        signed: true,
        maxAge: oneMonth,
        httpOnly: true,
      });
      const response = ({ id, email } = user);
      response.dataValues.token = token;
      response.dataValues.password = '';
      return res.json(response);
    }
  } catch (err) {
    console.log(err);
    res.status(401).json({ message: 'Incorrect credentials' });
  }
};

exports.updateStarsGems = async (req, res) => {
  try {
    const {
      token, stars, gems,
    } = req.body;
    if (!token) throw new Error('No token provided');
    const { id } = await verify(token, process.env.SECRET);
    let user = await User.findByPk(id);
    // console.log(user.dataValues.stars, user.dataValues.gems);
    if (!user) throw new Error('User not found');
    user.update({ stars: user.dataValues.stars + stars });
    // if date is more than 24 hours timestamp, update gems
    if (((Date.now() - Date.parse(user.dataValues.lastsignedin)) / 1000 / 60 / 60 / 24) > 1
    || !user.dataValues.firsttimegems) {
      // console.log('gems updated');
      user.update({ gems: user.dataValues.gems + gems, firsttimegems: true });
      res.status(200).send('stars and gems updated');
      return;
    }
    res.status(200).send('stars updated');
  } catch (err) {
    console.log(err);
    res.status(401).send('not authorized');
  }
};

exports.getHighScores = async (req, res) => {
  try {
    const users = await User.findAll({ attributes: ['name', 'stars', 'gems'] });
    users.sort((a, b) => b.stars - a.stars);
    res.status(200).send(users);
  } catch (err) {
    console.log(err);
    res.status(400).send('error');
  }
};
