const { DataTypes } = require('@sequelize/core');
const { sequelize } = require('../models/index');

const Card = sequelize.define('card', {
  front: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  back: {
    type: DataTypes.STRING,
  },
  cardset: {
    type: DataTypes.STRING,
  },
  image_url: {
    type: DataTypes.STRING,
  },
});

exports.getCards = async (req, res) => {
  try {
    const cards = await Card.findAll({ raw: true });
    // console.log(cards);
    res.status(200).send(cards);
  } catch (error) {
    // console.error('Unable to connect to the database:', error);
    return error;
  }
};

exports.createCard = async (req, res) => {
  const { front, back, cardSet } = req.body;

  try {
    const card = await Card.create({
      front, back, cardset: cardSet, image_url: null,
    });
    return res.status(201).json(card);
  } catch (err) {
    // console.log(err);
    return res.status(500).json(err);
  }
};
