import React, { useEffect, useState } from 'react';
import { Dropdown } from 'react-bootstrap';
import MCQ from '../components/MCQ';

function PlayRound({ isAuthenticated }) {
  const [flashcards, setCards] = useState([]);
  const [cardset, setCardSet] = useState([]);
  const [gameCards, setGameCards] = useState([]);
  const [passCards, setPasscards] = useState([]);
  const [play, setPlay] = useState(false);

  const loadCards = async () => {
    const response = await fetch('/getcards');
    const data = await response.json();
    setCards(data);
  };

  useEffect(() => {
    loadCards();
  }, []);

  // get the cardset
  useEffect(() => {
    setCardSet([...new Set(flashcards.map((item) => item.cardset))]);
  }, [flashcards]);

  // set title, game in play, and flashcards2
  const filterCards = (ele) => {
    setPlay(true);
    setGameCards(flashcards.filter((card) => card.cardset === ele));
  };

  // pass 1 main card, and 3 back
  useEffect(() => {
    const gameArray = [];
    if (play) {
      // make array of gameCards.length x 1 correct, 3 incorrect subarrays
      for (let i = 0; i < gameCards.length; i += 1) {
        const temp = [{
          ...gameCards[i],
          original: true,
        }];
        const nums = [i];
        while (temp.length < 4) {
          let rand = Math.floor(Math.random() * gameCards.length);
          while (nums.indexOf(rand) > -1) {
            rand = Math.floor(Math.random() * gameCards.length);
          }
          nums.push(rand);
          temp.push(gameCards[rand]);
        }
        console.log(temp);
        // push 3 random cards into subarray
        // get number between 0 and 9
        gameArray.push(temp);
      }
    }
    // console.log(gameArray);
    setPasscards(gameArray);
  }, [play]);

  return (
    <div className="text-white">
      {!play
      && (
      <Dropdown>
        <Dropdown.Toggle className="my-3" variant="success" id="dropdown-basic">
          Choose cardset to play
        </Dropdown.Toggle>
        <Dropdown.Menu>
          {cardset.map((ele) => (
            <Dropdown.Item key={ele} onClick={() => filterCards(ele)}>{ele}</Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
      )}
      {play && <h2>{gameCards[0].cardset}</h2>}
      {play && <MCQ passCards={passCards} setPlay={setPlay} isAuthenticated={isAuthenticated} />}
    </div>
  );
}

export default PlayRound;
