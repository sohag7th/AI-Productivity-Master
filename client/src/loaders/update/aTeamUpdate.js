 import { toast } from "react-toastify"; 
 
const aTeamUpdate = (id, property ,task, refetch) => {

    const query = {

    }

    console.log("object")
    console.log(query)

    query[property] = task;

    console.log("object")
    console.log(query)
  
  
    fetch(`http://localhost:5000/api/v1/teams/${id}`,
            {
                method: 'PATCH',
                headers: {
                    'content-type': 'application/json',
                },
                body: JSON.stringify(query)
            })
            .then(res => res.json())
            .then(data => {
                console.log(data); 
                refetch();
                toast.success('Task created uccessfully', { autoClose: 1000 })
            })
            .catch(error => toast.error(error.message));

        return "Task Update Sucessfully";
};

export default aTeamUpdate;