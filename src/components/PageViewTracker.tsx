import {useEffect} from 'react'
import {useLocation} from 'react-router-dom'
import {supabase} from '../lib/supabase'
const sessionKey='arpal-analytics-session'
function getSessionId(){let id=sessionStorage.getItem(sessionKey);if(!id){id=crypto.randomUUID();sessionStorage.setItem(sessionKey,id)}return id}
export default function PageViewTracker(){const location=useLocation();useEffect(()=>{if(location.pathname.startsWith('/admin')||navigator.doNotTrack==='1')return;const width=window.innerWidth,device_type=width<768?'mobile':width<1024?'tablet':'desktop';const timer=window.setTimeout(()=>{void supabase.from('page_views').insert({session_id:getSessionId(),path:location.pathname,page_title:document.title.slice(0,300),referrer:document.referrer.slice(0,1000)||null,language:document.documentElement.lang||navigator.language,device_type})},500);return()=>window.clearTimeout(timer)},[location.pathname]);return null}
