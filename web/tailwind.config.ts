import type { Config } from 'tailwindcss';
import typography from '@tailwindcss/typography';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './lib/**/*.{js,ts,jsx,tsx,mdx}'
  ],
  theme: {
    extend: {
      colors: {
        night: '#0d0712',
        plum: '#160b1d',
        ember: '#ff6a3d',
        peach: '#ffd09a',
        flame: '#ff944d',
        gold: '#ffbd6a',
        cream: '#fff4e7'
      },
      boxShadow: {
        ember: '0 0 60px rgba(255, 106, 61, 0.35)',
        soft: '0 30px 100px rgba(0,0,0,0.35)'
      },
      backgroundImage: {
        'ember-radial': 'radial-gradient(circle at 50% 30%, rgba(255,106,61,0.24), rgba(22,11,29,0.1) 36%, rgba(13,7,18,0) 65%)',
        'cta': 'linear-gradient(135deg, #ffd09a 0%, #ff944d 45%, #ff6a3d 100%)'
      }
    },
  },
  plugins: [typography],
};
export default config;
