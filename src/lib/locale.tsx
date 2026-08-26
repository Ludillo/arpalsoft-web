import {createContext,useContext} from 'react'
import {useLocation} from 'react-router-dom'
export type Lang='es'|'en'|'pt'
const LocaleContext=createContext<Lang>('es')
export function useLang(){return useContext(LocaleContext)}
export function LocaleProvider({children}:{children:React.ReactNode}){const first=useLocation().pathname.split('/')[1];const lang:Lang=first==='en'||first==='pt'?first:'es';return <LocaleContext.Provider value={lang}>{children}</LocaleContext.Provider>}
export const routes={
 es:{home:'/',solutions:'/soluciones',about:'/nosotros',contact:'/contacto'},
 en:{home:'/en',solutions:'/en/solutions',about:'/en/about',contact:'/en/contact'},
 pt:{home:'/pt',solutions:'/pt/solucoes',about:'/pt/sobre',contact:'/pt/contato'}
}
export function useRoutes(){return routes[useLang()]}
