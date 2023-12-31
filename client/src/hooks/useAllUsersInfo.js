/* eslint-disable react-hooks/rules-of-hooks */
import { useEffect, useState } from 'react'; 
import { toast } from 'react-toastify'; 

// eslint-disable-next-line no-unused-vars
const useAllUsersInfo = () => {

    const [allUsersInfo, setAllUsersInfo] = useState([]);
    const [allUsersInfoLoading, setAllUsersInfoLoading] = useState(false);

    useEffect(() => {
        setAllUsersInfoLoading(true); 
        
        fetch(`https://api-ai-one.vercel.app/api/v1/users`)
            .then(res => res.json())
            .then(res => {


                setAllUsersInfo(res.data);
                setAllUsersInfoLoading(false);
            })
            .catch(error => {
                toast.error(error.message);
                setAllUsersInfoLoading(false);
            })

    }, [])


    return [allUsersInfo, allUsersInfoLoading];
};

export default useAllUsersInfo;