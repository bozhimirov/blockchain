import "./MyButton.css";

// import { useState } from "react";

// export default function MyButton() {
//   const user = "Stanley";
//   return (
//     <>
//       <h1> My name is</h1> <h1>{user}</h1>
//     </>
//   );
// }

// export default function MyButton() {

//   function handleClick() {
//     alert("You clicked me!");
//   }
//   return <button onClick={handleClick}>Click me </button>;
// }

export default function MyButton({ count, buttonClicked }) {
  //   // declare state variable
  //   const [count, setCount] = useState(0);

  //   function handleClick() {
  //     //update the state variable value
  //     setCount(count + 1);
  //   }

  return <button onClick={buttonClicked}>Clicked {count} times </button>;
}
