import {useEffect,useState} from 'react'
import {Navigate,Outlet} from 'react-router-dom'
import {supabase} from '../lib/supabase'
export default function RequireAdmin(){const[s,setS]=useState<'loading'|'ok'|'no'>('loading');useEffect(()=>{(async()=>{const{data:{user}}=await supabase.auth.getUser();if(!user)return setS('no');const{data}=await supabase.rpc('is_admin');setS(data===true?'ok':'no')})()},[]);if(s==='loading')return <div className="admin-loading">Validando acceso...</div>;return s==='ok'?<Outlet/>:<Navigate to="/admin/login" replace/>}
