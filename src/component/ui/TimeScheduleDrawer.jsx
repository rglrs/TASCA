import React, { useState } from 'react';

const TimeScheduleDrawer = () => {
   const [businessHours, setBusinessHours] = useState(true);
   const [timezones, setTimezones] = useState('');
   const [schedule, setSchedule] = useState({
      monday: { start: '09:00', end: '18:00', active: true },
      tuesday: { start: '09:00', end: '18:00', active: false },
      wednesday: { start: '09:00', end: '18:00', active: true },
      thursday: { start: '09:00', end: '18:00', active: false },
      friday: { start: '09:00', end: '18:00', active: true },
   });

   const handleToggleBusinessHours = () => {
      setBusinessHours(!businessHours);
   };

   const handleTimezoneChange = (e) => {
      setTimezones(e.target.value);
   };

   const handleTimeChange = (day, type, value) => {
      setSchedule({
         ...schedule,
         [day]: { ...schedule[day], [type]: value },
      });
   };

   const handleSubmit = (e) => {
      e.preventDefault();
      // Handle form submission logic here
      console.log('Schedule saved:', { businessHours, timezones, schedule });
   };

   return (
      <div className="fixed top-0 left-0 z-40 h-screen p-4 overflow-y-auto bg-white w-96 dark:bg-gray-800">
         <h5 className="inline-flex items-center mb-6 text-base font-semibold text-gray-500 uppercase dark:text-gray-400">Time schedule</h5>
         <button type="button" className="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 absolute top-2.5 right-2.5 inline-flex items-center justify-center dark:hover:bg-gray-600 dark:hover:text-white">
            <svg className="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
               <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6" />
            </svg>
            <span className="sr-only">Close menu</span>
         </button>
         <form onSubmit={handleSubmit}>
            <div className="rounded-lg border border-gray-200 bg-gray-50 p-4 dark:border-gray-600 dark:bg-gray-700 mb-6">
               <div className="flex justify-between items-center mb-3">
                  <span className="text-gray-900 dark:text-white text-base font-medium">Business hours</span>
                  <label className="inline-flex items-center cursor-pointer">
                     <input type="checkbox" checked={businessHours} onChange={handleToggleBusinessHours} className="sr-only peer" />
                     <div className="relative w-11 h-6 bg-gray-200 rounded-full peer peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 dark:bg-gray-600 peer-checked:bg-blue-600 dark:peer-checked:bg-blue-600"></div>
                     <span className="sr-only">Business hours</span>
                  </label>
               </div>
               <p className="text-sm text-gray-500 dark:text-gray-400 font-normal">Enable or disable business working hours for all weekly working days</p>
            </div>
            <div className="pb-6 mb-6 border-b border-gray-200 dark:border-gray-700">
               <label htmlFor="timezones" className="flex items-center mb-2 text-sm font-medium text-gray-900 dark:text-white">
                  <span className="me-1">Select a timezone</span>
                  <select id="timezones" value={timezones} onChange={handleTimezoneChange} className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required>
                     <option value="">Choose a timezone</option>
                     <option value="America/New_York">EST (Eastern Standard Time) - GMT-5 (New York)</option>
                     <option value="America/Los_Angeles">PST (Pacific Standard Time) - GMT-8 (Los Angeles)</option>
                     <option value="Europe/London">GMT (Greenwich Mean Time) - GMT+0 (London)</option>
                     <option value="Europe/Paris">CET (Central European Time) - GMT+1 (Paris)</option>
                     <option value="Asia/Tokyo">JST (Japan Standard Time) - GMT+9 (Tokyo)</option>
                     <option value="Australia/Sydney">AEDT (Australian Eastern Daylight Time) - GMT+11 (Sydney)</option>
                     <option value="Canada/Mountain">MST (Mountain Standard Time) - GMT-7 (Canada)</option>
                     <option value="Canada/Central">CST (Central Standard Time) - GMT-6 (Canada)</option>
                     <option value="Canada/Eastern">EST (Eastern Standard Time) - GMT-5 (Canada)</option>
                     <option value="Europe/Berlin">CET (Central European Time) - GMT+1 (Berlin)</option>
                     <option value="Asia/Dubai">GST (Gulf Standard Time) - GMT+4 (Dubai)</option>
                     <option value="Asia/Singapore">SGT (Singapore Standard Time) - GMT+8 (Singapore)</option>
                  </select>
               </label>
            </div>
            {Object.keys(schedule).map((day) => (
               <div className="mb-6" key={day}>
                  <div className="flex items-center justify-between">
                     <div className="flex items-center min-w-[4rem]">
                        <input
                           id={day}
                           name="days"
                           type="checkbox"
                           checked={schedule[day].active}
                           onChange={() => handleTimeChange(day, 'active', !schedule[day].active)}
                           className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded-sm focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                        />
                        <label htmlFor={day} className="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300">{day.charAt(0).toUpperCase() + day.slice(1)}</label>
                     </div>
                     <div className="w-full max-w-[7rem]">
                        <label htmlFor={`start-time-${day}`} className="sr-only">Start time:</label>
                        <input
                           type="time"
                           id={`start-time-${day}`}
                           value={schedule[day].start}
                           onChange={(e) => handleTimeChange(day, 'start', e.target.value)}
                           className="bg-gray-50 border leading-none border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                           required
                        />
                     </div>
                     <div className="w-full max-w-[7rem]">
                        <label htmlFor={`end-time-${day}`} className="sr-only">End time:</label>
                        <input
                           type="time"
                           id={`end-time-${day}`}
                           value={schedule[day].end}
                           onChange={(e) => handleTimeChange(day, 'end', e.target.value)}
                           className="bg-gray-50 border leading-none border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                           required
                        />
                     </div>
                  </div>
               </div>
            ))}
            <button type="button" className="inline-flex items-center justify-center w-full py-2.5 mb-4 px-5 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700">
               <svg className="w-4 h-4 me-1" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
                  <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 12h14m-7 7V5" />
               </svg>
               Add interval
            </button>
            <div className="grid grid-cols-2 gap-4 bottom-4 left-0 w-full md:px-4 md:absolute">
               <button type="button" className="py-2.5 px-5 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700">Close</button>
               <button type="submit" className="text-white w-full inline-flex items-center justify-center bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
                  Save all
               </button>
            </div>
         </form>
      </div>
   );
};

export default TimeScheduleDrawer;