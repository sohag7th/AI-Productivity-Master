import React from 'react'
import { useContext } from 'react'
import {Link} from 'react-router-dom'
import { AuthContext } from '../../../context/AuthProvider'

const SignUp = () => {
    const {signUp} = useContext(AuthContext)
    const handleSignUp=event=>{
        event.preventDefault();
        const form = event.target;
        const name = form.name.value;
        const email= form.email.value;
        const password = form.password.value;
        const profile = {
            name,
            email,
            password
        }
        console.log(profile)
        signUp(email, password)
        .then(res=>{
            const user = res.user;
            console.log(user)
        })
    }
  return (
    <div className="hero min-h-screen bg-base-200">
  <div className="hero-content flex-col lg:flex-row-reverse">
    <div className="text-center lg:text-left">
    <h1 className="text-5xl font-bold">Register!</h1>
      <p className="py-6 capitalize">to create your own team and let the ai decide to manage the the task you just need to register</p>
    </div>
    <div className="card flex-shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
      <form onSubmit={handleSignUp} className="card-body">
        <div className="form-control">
          <label className="label">
            <span className="label-text">Username</span>
          </label>
          <input type="text" name='name' placeholder="username" className="input input-bordered" />
        </div>
        <div className="form-control">
          <label className="label">
            <span className="label-text">Email</span>
          </label>
          <input type="email" name='email' placeholder="email" className="input input-bordered" />
        </div>
        <div className="form-control">
          <label className="label">
            <span className="label-text">Password</span>
          </label>
          <input type="password" name='password' placeholder="password" className="input input-bordered" />
          <label className="label">
          <span className="label-text-alt">Already have an account? <Link className=' link link-hover' to="/signIn">Login</Link></span>
          </label>
        </div>
        <div className="form-control mt-6">
          {/* <button className="btn btn-primary">Login</button> */}
          <input type="submit" value="Register" className='btn btn-primary' />
        </div>
      </form>
    </div>
  </div>
</div>
  )
}

export default SignUp