/* eslint-disable react/prop-types */

const CommentsTable = ({ comments }) => {
    return (
        <div>
            {
                comments?.map((comment, index) => <div
                    key={index}
                    className="grid grid-cols-9 bg-purple-200 p-3 mb-1 rounded-lg "
                >
                    <p className="col-span-2 font-bold  text-blue-500  ">{comment?.user}</p>
                    <div className="col-span-7 flex" >
                        <p className="font-bold mx-2">:</p>
                        <p className="text-slate-600 ">{comment?.comment} </p>
                    </div>
                </div>)
            } 
        </div>
    );
};

export default CommentsTable;