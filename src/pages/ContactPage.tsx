import { FormEvent, useState } from 'react'
import { Mail, MapPin, Send } from 'lucide-react'
import { supabase } from '../lib/supabase'

export default function ContactPage() {
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
            setMsg('No fue posible enviar el mensaje.')
            return
        }

        setMsg('Gracias. Recibimos tu mensaje.')
        form.reset()
    }

    return (
        <section className="inner-page">
            <div className="container contact-grid">

                <div className="page-hero contact-copy">
                    <span className="section-kicker">CONTACTO</span>

                    <h1>Conversemos sobre el siguiente paso.</h1>

                    <p>Cuéntanos qué necesitas construir, integrar o modernizar.</p>

                    <div className="contact-points">
                        <span><Mail /> contacto@arpalsoft.com</span>
                        <span><MapPin /> Bolivia</span>
                    </div>
                </div>

                <form className="contact-form" onSubmit={submit}>

                    <div className="form-row">
                        <label>
                            Nombre
                            <input required name="full_name" />
                        </label>

                        <label>
                            Empresa
                            <input name="company" />
                        </label>
                    </div>

                    <div className="form-row">
                        <label>
                            Email
                            <input required type="email" name="email" />
                        </label>

                        <label>
                            Teléfono
                            <input name="phone" />
                        </label>
                    </div>

                    <label>
                        Asunto
                        <input name="subject" />
                    </label>

                    <label>
                        Mensaje
                        <textarea required name="message" rows={6} />
                    </label>

                    <button className="button button-primary" disabled={sending}>
                        <Send size={17} />
                        {sending ? 'Enviando...' : 'Enviar mensaje'}
                    </button>

                    {msg && <p className="form-message">{msg}</p>}

                </form>

            </div>
        </section>
    )
}