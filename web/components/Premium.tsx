import { Palette, Shield, Sparkles } from 'lucide-react';
import { SectionHeading } from './SectionHeading';

const items = [
  { icon: Sparkles, title: 'Bigger Flame cap', body: 'Premium gives more room for intentional time after Scripture and prayer.' },
  { icon: Palette, title: 'Custom Flame colors', body: 'Personalize the Flame without changing the core discipline.' },
  { icon: Shield, title: 'Web Guard', body: 'Help block adult websites where iOS supports web filtering. Third-party app feeds still require shielding the app itself.' }
];

export function Premium() {
  return (
    <section className="px-4 py-20 md:px-8 md:py-28">
      <div className="mx-auto max-w-6xl">
        <SectionHeading eyebrow="Premium" title="Keep your Flame burning longer." body="Premium is for users who want more flexibility while keeping Scripture and prayer first." />
        <div className="grid gap-5 md:grid-cols-3">
          {items.map((item) => (
            <div key={item.title} className="glass rounded-[2rem] p-6">
              <div className="mb-6 flex h-12 w-12 items-center justify-center rounded-2xl bg-cta text-black"><item.icon className="h-6 w-6" /></div>
              <h3 className="text-xl font-black text-cream">{item.title}</h3>
              <p className="mt-3 font-bold leading-7 text-cream/58">{item.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
