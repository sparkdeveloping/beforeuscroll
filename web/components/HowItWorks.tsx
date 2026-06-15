'use client';

import { motion } from 'framer-motion';
import { BookOpen, Flame, Lock, Sparkles } from 'lucide-react';
import { SectionHeading } from './SectionHeading';

const steps = [
  { icon: BookOpen, title: 'Read Scripture', body: 'Five thoughtful questions help you remember the words, reference, and meaning before the scroll.' },
  { icon: Sparkles, title: 'Pray with attention', body: 'Prayer Mode locks protected apps while you pray, then adds time based on your prayer.' },
  { icon: Flame, title: 'Keep the Flame alive', body: 'Your Flame drains automatically while protected apps are open.' },
  { icon: Lock, title: 'Protection returns', body: 'When the Flame reaches zero, selected apps lock again.' }
];

export function HowItWorks() {
  return (
    <section id="how" className="px-4 py-20 md:px-8 md:py-28">
      <div className="mx-auto max-w-7xl">
        <SectionHeading eyebrow="How it works" title="A spiritual recharge system, not another screen-time chart." body="BeforeUScroll turns access into a moment of attention. Read, pray, and use the window with purpose." />
        <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-4">
          {steps.map((step, i) => (
            <motion.div key={step.title} initial={{ opacity: 0, y: 24 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: '-80px' }} transition={{ delay: i * 0.08, duration: 0.55 }} className="glass group rounded-[2rem] p-6 transition hover:-translate-y-1 hover:bg-white/10">
              <div className="mb-8 flex h-14 w-14 items-center justify-center rounded-2xl bg-cta text-black shadow-ember">
                <step.icon className="h-7 w-7" />
              </div>
              <h3 className="text-2xl font-black tracking-[-0.03em] text-cream">{step.title}</h3>
              <p className="mt-4 text-base font-bold leading-7 text-cream/58">{step.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
