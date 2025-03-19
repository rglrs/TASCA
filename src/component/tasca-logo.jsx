import React from 'react';

const TascaLogo = ({ size = 'md', animated = true }) => {
  const textSizes = {
    sm: 'text-xl',
    md: 'text-2xl',
    lg: 'text-4xl',
    xl: 'text-5xl'
  };

  const letterClass = animated ? 'tasca-letter' : '';

  return (
    <div className={`font-bold ${textSizes[size]} tracking-wide inline-flex`}>
      <span className={`text-tasca-blue ${letterClass}`}>T</span>
      <span className={`text-tasca-blue ${letterClass}`}>A</span>
      <span className={`text-tasca-green ${letterClass}`}>S</span>
      <span className={`text-tasca-orange ${letterClass}`}>C</span>
      <span className={`text-tasca-orange ${letterClass}`}>A</span>
    </div>
  );
};

export default TascaLogo;