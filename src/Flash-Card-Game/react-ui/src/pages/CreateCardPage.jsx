import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';

function CreateCardPage() {
  const [front, setFront] = useState('');
  const [back, setBack] = useState('');
  const [cardSet, setCardSet] = useState('');

  const history = useHistory();

  const addCard = async () => {
    const newCard = { front, back, cardSet };
    const response = await fetch('/createcard', {
      method: 'POST',
      body: JSON.stringify(newCard),
      headers: {
        'Content-Type': 'application/json',
      },
    });
    if (response.status === 201) {
      alert('Successfully added flashcard!');
    } else {
      alert(`Failed to add flashcard, status code = ${response.status}`);
    }
    history.push('/');
  };

  return (
    <div className="text-light">
      <h1>Add a Flashcard</h1>
      <div>
        <label htmlFor="inputFront">
          Front
          <br />
          <textarea
            id="inputFront"
            type="text"
            placeholder="Enter front here"
            value={front}
            onChange={(e) => setFront(e.target.value)}
          />
        </label>
        <br />
        <label htmlFor="inputBack">
          Back
          <br />
          <textarea
            id="inputBack"
            type="text"
            placeholder="Enter back here"
            value={back}
            onChange={(e) => setBack(e.target.value)}
          />
        </label>
        <br />
        <label htmlFor="inputTopic">
          Topic
          <br />
          <textarea
            id="inputTopic"
            type="text"
            placeholder="Enter topic here"
            value={cardSet}
            onChange={(e) => setCardSet(e.target.value)}
          />
        </label>
        <br />
      </div>
      <button
        onClick={addCard}
        type="button"
      >
        Add
      </button>
    </div>
  );
}

export default CreateCardPage;
