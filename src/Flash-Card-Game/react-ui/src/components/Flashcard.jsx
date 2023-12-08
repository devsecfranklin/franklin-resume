import React, { useState, useEffect, useRef } from 'react';

function Flashcard({ flashcard }) {
  const [flip, setFlip] = useState(false);
  const [height, setHeight] = useState('initial');

  const frontEl = useRef();
  const backEl = useRef();

  function setMaxHeight() {
    const frontHeight = frontEl.current.getBoundingClientRect().height;
    const backHeight = backEl.current.getBoundingClientRect().height;
    setHeight(Math.max(frontHeight, backHeight, 100));
  }

  useEffect(setMaxHeight, [flashcard.front, flashcard.back]);
  useEffect(() => {
    window.addEventListener('resize', setMaxHeight);
    return () => window.removeEventListener('resize', setMaxHeight);
  }, []);

  return (
    <div
      className={`card ${flip ? 'flip' : ''} `}
      style={{ height }}
      onClick={() => setFlip(!flip)}
      role="presentation"
    >
      <div className="front" ref={frontEl}>
        {flashcard.front}
      </div>
      <div className="back" ref={backEl}>
        {flashcard.back}
      </div>
    </div>
  );
}

export default Flashcard;
