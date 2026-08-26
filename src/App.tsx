import {Navigate,Route,Routes} from 'react-router-dom'
import SiteLayout from './components/SiteLayout'
import RequireAdmin from './components/RequireAdmin'
import AdminLayout from './components/AdminLayout'
import HomePage from './pages/HomePage'
import ServicesPage from './pages/ServicesPage'
import AboutPage from './pages/AboutPage'
import ContactPage from './pages/ContactPage'
import InternationalHomePage from './pages/InternationalHomePage'
import AdminLoginPage from './pages/admin/AdminLoginPage'
import AdminDashboardPage from './pages/admin/AdminDashboardPage'
import AdminSectionsPage from './pages/admin/AdminSectionsPage'
import AdminServicesPage from './pages/admin/AdminServicesPage'
import AdminContactsPage from './pages/admin/AdminContactsPage'
import AdminClientsPage from './pages/admin/AdminClientsPage'
export default function App(){return <Routes>
<Route element={<SiteLayout/>}><Route path="/" element={<HomePage/>}/><Route path="/soluciones" element={<ServicesPage/>}/><Route path="/nosotros" element={<AboutPage/>}/><Route path="/contacto" element={<ContactPage/>}/><Route path="/en" element={<InternationalHomePage/>}/><Route path="/en/solutions" element={<ServicesPage/>}/><Route path="/en/about" element={<AboutPage/>}/><Route path="/en/contact" element={<ContactPage/>}/><Route path="/pt" element={<InternationalHomePage/>}/><Route path="/pt/solucoes" element={<ServicesPage/>}/><Route path="/pt/sobre" element={<AboutPage/>}/><Route path="/pt/contato" element={<ContactPage/>}/></Route>
<Route path="/admin/login" element={<AdminLoginPage/>}/>
<Route element={<RequireAdmin/>}><Route path="/admin" element={<AdminLayout/>}><Route index element={<AdminDashboardPage/>}/><Route path="secciones" element={<AdminSectionsPage/>}/><Route path="servicios" element={<AdminServicesPage/>}/><Route path="clientes" element={<AdminClientsPage/>}/><Route path="contactos" element={<AdminContactsPage/>}/></Route></Route>
<Route path="*" element={<Navigate to="/" replace/>}/></Routes>}
