import React, { useEffect, useState } from 'react';
import { Dropdown } from 'react-bootstrap';
import Flashcardgroup from '../components/Flashcardgroup';

function HomePage() {
  const [flashcards, setCards] = useState([]);
  const [flashcards2, setCards2] = useState([]);
  const [cardset, setCardSet] = useState([]);

  const loadCards = async () => {
    const response = await fetch('/getcards');
    const data = await response.json();
    setCards(data);
    setCards2(data);
  };

  useEffect(() => {
    loadCards();
  }, []);

  // get the cardset
  useEffect(() => {
    setCardSet([...new Set(flashcards.map((item) => item.cardset))]);
  }, [flashcards]);

  const filterCards = (ele) => {
    setCards2(flashcards.filter((card) => card.cardset === ele));
  };

  return (
    <div className="d-flex flex-column">
      <h1 className="text-light">Home Page</h1>
      <Dropdown>
        <Dropdown.Toggle className="my-3" variant="success" id="dropdown-basic">
          Filter by
        </Dropdown.Toggle>
        <Dropdown.Menu>
          {cardset.map((ele) => (
            <Dropdown.Item key={ele} onClick={() => filterCards(ele)}>{ele}</Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
      <div className="container my-5">
        <Flashcardgroup flashcards={flashcards2} />
      </div>
    </div>
  );
}

export default HomePage;
