import { FormEvent, useState } from 'react'
import { Mail, MapPin, Send } from 'lucide-react'
import { supabase } from '../lib/supabase'
import {useLang} from '../lib/locale'
const copy={es:{kicker:'CONTACTO',title:'Conversemos sobre el siguiente paso.',description:'Cuéntanos qué necesitas construir, integrar o modernizar.',name:'Nombre',company:'Empresa',phone:'Teléfono',subject:'Asunto',message:'Mensaje',send:'Enviar mensaje',sending:'Enviando...',error:'No fue posible enviar el mensaje.',thanks:'Gracias. Recibimos tu mensaje.'},en:{kicker:'CONTACT',title:"Let's discuss your next step.",description:'Tell us what you need to build, integrate, or modernize.',name:'Name',company:'Company',phone:'Phone',subject:'Subject',message:'Message',send:'Send message',sending:'Sending...',error:'Your message could not be sent.',thanks:'Thank you. We received your message.'},pt:{kicker:'CONTATO',title:'Vamos conversar sobre o próximo passo.',description:'Conte-nos o que você precisa construir, integrar ou modernizar.',name:'Nome',company:'Empresa',phone:'Telefone',subject:'Assunto',message:'Mensagem',send:'Enviar mensagem',sending:'Enviando...',error:'Não foi possível enviar sua mensagem.',thanks:'Obrigado. Recebemos sua mensagem.'}}

export default function ContactPage() {
    const t=copy[useLang()]
    const [sending, setSending] = useState(false)
    const [msg, setMsg] = useState('')

    async function submit(e: FormEvent<HTMLFormElement>) {
        e.preventDefault()
        setSending(true)
        setMsg('')

        const form = e.currentTarget
        const f = new FormData(form)

        const payload = {
            full_name: String(f.get('full_name') || '').trim(),
            company: String(f.get('company') || '').trim() || null,
            email: String(f.get('email') || '').trim().toLowerCase(),
            phone: String(f.get('phone') || '').trim() || null,
            subject: String(f.get('subject') || '').trim() || null,
            message: String(f.get('message') || '').trim(),
            status: 'new'
        }

        const { error } = await supabase.from('contact_messages').insert(payload)

        setSending(false)

        if (error) {
            console.error('ERROR CONTACTO SUPABASE:', error)
            setMsg(t.error)
            return
        }

        setMsg(t.thanks)
        form.reset()
    }

    return (
        <section className="inner-page">
            <div className="container contact-grid">

                <div className="page-hero contact-copy">
                    <span className="section-kicker">{t.kicker}</span>

                    <h1>{t.title}</h1>

                    <p>{t.description}</p>

                    <div className="contact-points">
                        <span><Mail /> contacto@arpalsoft.com</span>
                        <span><MapPin /> Bolivia</span>
                    </div>
                </div>

                <form className="contact-form" onSubmit={submit}>

                    <div className="form-row">
                        <label>
                            {t.name}
                            <input required name="full_name" />
                        </label>

                        <label>
                            {t.company}
                            <input name="company" />
                        </label>
                    </div>

                    <div className="form-row">
                        <label>
                            Email
                            <input required type="email" name="email" />
                        </label>

                        <label>
                            {t.phone}
                            <input name="phone" />
                        </label>
                    </div>

                    <label>
                        {t.subject}
                        <input name="subject" />
                    </label>

                    <label>
                        {t.message}
                        <textarea required name="message" rows={6} />
                    </label>

                    <button className="button button-primary" disabled={sending}>
                        <Send size={17} />
                        {sending ? t.sending : t.send}
                    </button>

                    {msg && <p className="form-message">{msg}</p>}

                </form>

            </div>
        </section>
    )
}
