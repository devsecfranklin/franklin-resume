import React from 'react';
import Flashcard from './Flashcard';

function Flashcardgroup({ flashcards }) {
  return (
    <div className="card-grid">
      {flashcards.map((flashcard) => (
        <Flashcard flashcard={flashcard} key={flashcard.id} />
      ))}
    </div>
  );
}

export default Flashcardgroup;
