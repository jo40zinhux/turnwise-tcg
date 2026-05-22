(function () {
  const config = window.TURNWISE_DOWNLOADS ?? {};
  const year = document.getElementById('year');
  const navToggle = document.querySelector('.nav-toggle');
  const nav = document.querySelector('.site-nav');

  if (year) year.textContent = String(new Date().getFullYear());

  if (config.testflightUrl) {
    document
      .querySelectorAll('#btn-testflight, [data-download-ios]')
      .forEach((el) => {
        el.href = config.testflightUrl;
      });
  }
  if (config.androidApkUrl) {
    document
      .querySelectorAll('#btn-android, [data-download-android]')
      .forEach((el) => {
        el.href = config.androidApkUrl;
      });
  }

  const supportLinks = document.querySelectorAll('[data-support-email]');
  if (config.supportEmail) {
    supportLinks.forEach((el) => {
      el.href = `mailto:${config.supportEmail}`;
      if (el.dataset.supportEmail === 'text') {
        el.textContent = config.supportEmail;
      }
    });
  }

  navToggle?.addEventListener('click', () => {
    const open = nav?.classList.toggle('is-open');
    navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  });

  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener('click', (e) => {
      const id = anchor.getAttribute('href');
      if (!id || id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      nav?.classList.remove('is-open');
      navToggle?.setAttribute('aria-expanded', 'false');
    });
  });
})();
