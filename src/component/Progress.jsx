const Progress = ({ value, className }) => {
    return (
      <div className={`w-full bg-gray-200 rounded-full h-2 ${className}`}>
        <div
          className="bg-red-500 h-full rounded-full transition-all duration-300"
          style={{ width: `${value}%` }}
        ></div>
      </div>
    );
  };
  
  export default Progress;