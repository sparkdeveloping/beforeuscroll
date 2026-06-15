export const site = {
  name: 'BeforeUScroll',
  url: 'https://beforeuscroll.vercel.app',
  appStoreUrl: process.env.NEXT_PUBLIC_APP_STORE_URL || '#download',
  supportEmail: process.env.NEXT_PUBLIC_SUPPORT_EMAIL || 'denzelnyatsanza@gmail.com',
  links: {
    privacy: '/privacy',
    terms: '/terms',
    support: '/support'
  }
};

export const screenshotSet = [
  { src: '/screens/home-flame.webp', alt: 'BeforeUScroll Flame home screen', label: 'Flame home' },
  { src: '/screens/scripture-verse.webp', alt: 'Scripture reading screen', label: 'Read carefully' },
  { src: '/screens/scripture-question.webp', alt: 'Scripture question screen', label: 'Remember Scripture' },
  { src: '/screens/scripture-result.webp', alt: 'Scripture remembered result', label: 'Flame refilled' },
  { src: '/screens/prayer-mode.webp', alt: 'Prayer Mode screen', label: 'Prayer Mode' },
  { src: '/screens/choose-focus.webp', alt: 'Choose your focus onboarding screen', label: 'Choose focus' }
];

export const features = [
  {
    title: 'Read Scripture to keep your Flame alive',
    body: 'Before distracting apps open freely, BeforeUScroll asks you to slow down, read carefully, and remember the verse.'
  },
  {
    title: 'Prayer adds intentional time',
    body: 'Prayer Mode locks protected apps while you pray, then adds time based on the minutes you spent in prayer.'
  },
  {
    title: 'Apps lock when the Flame burns out',
    body: 'The Flame drains automatically. When it reaches zero, protection returns without you needing to decide again.'
  },
  {
    title: 'Private by design',
    body: 'BeforeUScroll uses Apple Screen Time tokens. It does not read your messages, feeds, browsing content, or screen.'
  }
];
