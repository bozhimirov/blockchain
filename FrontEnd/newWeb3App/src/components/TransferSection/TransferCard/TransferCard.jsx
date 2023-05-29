import React from "react";

import "./TransferCard.css";

const TransferCard = ({ from, value }) => {
  return (
    <div className="transfer-card">
      <h3>To: {from}</h3>
      <p>Value: {value}</p>
    </div>
  );
};

export default TransferCard;
