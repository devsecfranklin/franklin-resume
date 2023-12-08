import React, { useEffect, useState } from 'react';
import { Button } from 'react-bootstrap';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import axios from 'axios';

function shuffle(array) {
  let currentIndex = array.length; let
    randomIndex;

  // While there remain elements to shuffle...
  while (currentIndex !== 0) {
    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    [array[currentIndex], array[randomIndex]] = [
      array[randomIndex], array[currentIndex]];
  }

  return array;
}

function MCQ({ passCards, setPlay, isAuthenticated }) {
  toast.configure();

  const [counter, setCounter] = useState(0);
  const [correct, setCorrect] = useState(0);
  const [original, setOriginal] = useState({});
  const [answers, setAnswers] = useState({});
  const [gameOver, setGameOver] = useState(false);

  const runCards = () => {
    shuffle(passCards[counter]);
    //   console.log(passCards[counter]);
    const og = passCards[counter].find((ele) => ele.original);
    setOriginal(og);
    setAnswers(passCards[counter]);
  };

  const restart = () => {
    setCounter(0);
    setCorrect(0);
    setGameOver(false);
    setPlay(false);
  };

  useEffect(() => {
    if (passCards.length > 0 && counter === 0) {
      runCards();
    }
  }, [passCards]);

  const increaseUserStars = async () => {
    const data = await axios.post(`${process.env.REACT_APP_API_URL}/update-stars-gems`, {
      token: localStorage.getItem('token'),
      stars: 10,
      gems: 1,
    });
    console.log(data);
    if (data.data === 'stars and gems updated') {
      toast('1 gem awarded :)');
    }
  };

  const checkCorrect = (answer) => {
    if (gameOver) {
      toast('round is over :)');
      return;
    }
    if (answer.id === original.id) {
      toast('Good job!');
      setCorrect(correct + 1);
    } else {
      toast('Oops!');
    }
    setCounter(counter + 1);
    runCards();
  };

  // check if round is finished
  useEffect(() => {
    if (counter === 10) {
      toast('round over!');
      if (!isAuthenticated) {
        toast('Please sign in to earn stars!');
      }
      if (correct > 8 && isAuthenticated) {
        toast('You earned 10 stars');
        increaseUserStars();
      }
      setGameOver(true);
    }
  }, [counter]);

  return (
    <div className="d-flex justify-content-center">
      <div className="mx-auto mw-600">
        <br />
        <h4 className="my-5">
          {original?.front}
        </h4>
        {answers.length > 0 && answers.map((answer) => (
          <div className="my-3 mcq" onClick={() => checkCorrect(answer)} role="presentation">{answer.back}</div>
        ))}
        <div className="my-5">
          Rounds played:
          {' '}
          {counter}
          &nbsp;
          /&nbsp;10
        </div>
        <div className="my-5">
          Correct:
          {' '}
          {correct}
          &nbsp;
          /&nbsp;10
        </div>
        {gameOver && <Button onClick={restart}>Restart</Button>}
      </div>
    </div>
  );
}

export default MCQ;
