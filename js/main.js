/* ===================================================
   MAIN JAVASCRIPT - Casey Kuhl Interactive Resume
   =================================================== */

document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    initScrollReveal();
    initTimeline();
    initSkillBars();
    initRadarChart();
    initCounters();
    initGallery();
    initParticles();
});

/* ===========================
   NAVIGATION
   =========================== */
function initNavigation() {
    const navbar = document.getElementById('navbar');
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');
    const navLinks = document.querySelectorAll('.nav-link');

    // Scroll effect
    window.addEventListener('scroll', () => {
        navbar.classList.toggle('scrolled', window.scrollY > 50);
        updateActiveNav();
    });

    // Mobile toggle
    navToggle.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        navToggle.classList.toggle('active');
    });

    // Close menu on link click
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
            navToggle.classList.remove('active');
        });
    });

    // Close menu on outside click
    document.addEventListener('click', (e) => {
        if (!navMenu.contains(e.target) && !navToggle.contains(e.target)) {
            navMenu.classList.remove('active');
            navToggle.classList.remove('active');
        }
    });
}

function updateActiveNav() {
    const sections = document.querySelectorAll('.section, .hero');
    const navLinks = document.querySelectorAll('.nav-link');
    let current = '';

    sections.forEach(section => {
        const sectionTop = section.offsetTop - 100;
        if (window.scrollY >= sectionTop) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
}

/* ===========================
   SCROLL REVEAL
   =========================== */
function initScrollReveal() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });

    document.querySelectorAll('.reveal-up, .reveal-left, .reveal-right').forEach(el => {
        observer.observe(el);
    });
}

/* ===========================
   TIMELINE INTERACTIVITY
   =========================== */
function initTimeline() {
    const cards = document.querySelectorAll('.timeline-card');
    cards.forEach(card => {
        card.addEventListener('click', () => {
            const wasActive = card.classList.contains('active');
            // Close all
            cards.forEach(c => c.classList.remove('active'));
            // Toggle clicked
            if (!wasActive) {
                card.classList.add('active');
            }
        });
    });
}

/* ===========================
   SKILL BARS ANIMATION
   =========================== */
function initSkillBars() {
    const bars = document.querySelectorAll('.skill-bar');
    bars.forEach(bar => {
        const level = bar.getAttribute('data-level');
        bar.style.setProperty('--skill-level', level + '%');
        // Add percentage label
        const pct = document.createElement('span');
        pct.className = 'skill-percent';
        pct.textContent = level + '%';
        bar.appendChild(pct);
    });

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animated');
            }
        });
    }, { threshold: 0.3 });

    bars.forEach(bar => observer.observe(bar));
}

/* ===========================
   RADAR CHART (Canvas)
   =========================== */
function initRadarChart() {
    const canvas = document.getElementById('radarChart');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    // High-DPI support
    const dpr = window.devicePixelRatio || 1;
    const size = Math.min(canvas.parentElement.offsetWidth - 40, 500);
    canvas.width = size * dpr;
    canvas.height = size * dpr;
    canvas.style.width = size + 'px';
    canvas.style.height = size + 'px';
    ctx.scale(dpr, dpr);

    const centerX = size / 2;
    const centerY = size / 2;
    const maxRadius = size / 2 - 60;

    const labels = [
        'Technical Info Dev',
        'People Leadership',
        'Global Collaboration',
        'Process Improvement',
        'Digital Transformation',
        'Customer Focus',
        'Project Management',
        'Strategic Planning'
    ];

    const values = [95, 93, 90, 90, 88, 92, 87, 87];
    const numAxes = labels.length;
    const angleStep = (2 * Math.PI) / numAxes;
    const startAngle = -Math.PI / 2;

    // Animate values from 0
    let animProgress = 0;
    const animDuration = 60; // frames

    const radarObserver = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting) {
            animProgress = 0;
            animateRadar();
            radarObserver.unobserve(canvas);
        }
    }, { threshold: 0.3 });
    radarObserver.observe(canvas);

    function animateRadar() {
        animProgress++;
        const t = Math.min(animProgress / animDuration, 1);
        const eased = 1 - Math.pow(1 - t, 3); // ease-out cubic
        drawRadar(eased);
        if (t < 1) requestAnimationFrame(animateRadar);
    }

    function drawRadar(t) {
        ctx.clearRect(0, 0, size, size);

        // Draw grid rings
        for (let ring = 1; ring <= 5; ring++) {
            const r = (maxRadius / 5) * ring;
            ctx.beginPath();
            for (let i = 0; i <= numAxes; i++) {
                const angle = startAngle + angleStep * i;
                const x = centerX + r * Math.cos(angle);
                const y = centerY + r * Math.sin(angle);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
            ctx.lineWidth = 1;
            ctx.stroke();
        }

        // Draw axes
        for (let i = 0; i < numAxes; i++) {
            const angle = startAngle + angleStep * i;
            ctx.beginPath();
            ctx.moveTo(centerX, centerY);
            ctx.lineTo(centerX + maxRadius * Math.cos(angle), centerY + maxRadius * Math.sin(angle));
            ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
            ctx.lineWidth = 1;
            ctx.stroke();
        }

        // Draw data polygon
        ctx.beginPath();
        for (let i = 0; i <= numAxes; i++) {
            const idx = i % numAxes;
            const angle = startAngle + angleStep * idx;
            const val = (values[idx] / 100) * maxRadius * t;
            const x = centerX + val * Math.cos(angle);
            const y = centerY + val * Math.sin(angle);
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }
        ctx.fillStyle = 'rgba(54, 124, 43, 0.25)';
        ctx.fill();
        ctx.strokeStyle = '#4a9e3a';
        ctx.lineWidth = 2;
        ctx.stroke();

        // Draw data points
        for (let i = 0; i < numAxes; i++) {
            const angle = startAngle + angleStep * i;
            const val = (values[i] / 100) * maxRadius * t;
            const x = centerX + val * Math.cos(angle);
            const y = centerY + val * Math.sin(angle);
            ctx.beginPath();
            ctx.arc(x, y, 5, 0, Math.PI * 2);
            ctx.fillStyle = '#ffde00';
            ctx.fill();
            ctx.strokeStyle = '#367c2b';
            ctx.lineWidth = 2;
            ctx.stroke();
        }

        // Draw labels
        ctx.fillStyle = '#a0a0b0';
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'center';
        for (let i = 0; i < numAxes; i++) {
            const angle = startAngle + angleStep * i;
            const labelRadius = maxRadius + 35;
            let x = centerX + labelRadius * Math.cos(angle);
            let y = centerY + labelRadius * Math.sin(angle);

            // Adjust alignment based on position
            if (Math.cos(angle) < -0.1) ctx.textAlign = 'right';
            else if (Math.cos(angle) > 0.1) ctx.textAlign = 'left';
            else ctx.textAlign = 'center';

            ctx.fillText(labels[i], x, y + 4);
        }
        ctx.textAlign = 'center'; // Reset
    }
}

/* ===========================
   ANIMATED COUNTERS
   =========================== */
function initCounters() {
    const counters = document.querySelectorAll('.highlight-number, .metric-value');

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(counter => observer.observe(counter));
}

function animateCounter(el) {
    const target = parseInt(el.getAttribute('data-target'));
    const duration = 2000;
    const start = performance.now();

    function update(now) {
        const elapsed = now - start;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        const current = Math.round(target * eased);
        el.textContent = current.toLocaleString();
        if (progress < 1) requestAnimationFrame(update);
    }

    requestAnimationFrame(update);
}

/* ===========================
   GALLERY
   =========================== */
function initGallery() {
    const grid = document.getElementById('galleryGrid');
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightboxImage');
    const closeBtn = document.querySelector('.lightbox-close');
    const prevBtn = document.querySelector('.lightbox-prev');
    const nextBtn = document.querySelector('.lightbox-next');

    // Gallery images (larger images from the pptx - skip very small ones)
    const galleryImages = [];
    const allImages = [
        { src: 'assets/images/pptx_image_3.png', large: true },
        { src: 'assets/images/pptx_image_4.png', large: false },
        { src: 'assets/images/pptx_image_5.png', large: false },
        { src: 'assets/images/pptx_image_6.png', large: true },
        { src: 'assets/images/pptx_image_7.png', large: false },
        { src: 'assets/images/pptx_image_8.png', large: false },
        { src: 'assets/images/pptx_image_19.png', large: false },
        { src: 'assets/images/isg-pune.jpg', large: true },
        { src: 'assets/images/pptx_image_25.png', large: true },
        { src: 'assets/images/pptx_image_26.png', large: true },
    ];

    allImages.forEach((img, i) => {
        const item = document.createElement('div');
        item.className = 'gallery-item' + (img.large ? ' large' : '');
        item.innerHTML = `<img src="${img.src}" alt="Gallery image ${i + 1}" loading="lazy">`;
        item.addEventListener('click', () => openLightbox(i));
        grid.appendChild(item);
        galleryImages.push(img.src);
    });

    let currentIndex = 0;

    function openLightbox(index) {
        currentIndex = index;
        lightboxImg.src = galleryImages[currentIndex];
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeLightbox() {
        lightbox.classList.remove('active');
        document.body.style.overflow = '';
    }

    function navigate(dir) {
        currentIndex = (currentIndex + dir + galleryImages.length) % galleryImages.length;
        lightboxImg.src = galleryImages[currentIndex];
    }

    closeBtn.addEventListener('click', closeLightbox);
    prevBtn.addEventListener('click', () => navigate(-1));
    nextBtn.addEventListener('click', () => navigate(1));

    lightbox.addEventListener('click', (e) => {
        if (e.target === lightbox) closeLightbox();
    });

    document.addEventListener('keydown', (e) => {
        if (!lightbox.classList.contains('active')) return;
        if (e.key === 'Escape') closeLightbox();
        if (e.key === 'ArrowLeft') navigate(-1);
        if (e.key === 'ArrowRight') navigate(1);
    });
}

/* ===========================
   BACKGROUND PARTICLES
   =========================== */
function initParticles() {
    const hero = document.querySelector('.hero-bg-animation');
    if (!hero) return;

    for (let i = 0; i < 20; i++) {
        const particle = document.createElement('div');
        particle.style.cssText = `
            position: absolute;
            width: ${Math.random() * 4 + 2}px;
            height: ${Math.random() * 4 + 2}px;
            background: rgba(54, 124, 43, ${Math.random() * 0.3 + 0.1});
            border-radius: 50%;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            --tx: ${(Math.random() - 0.5) * 200}px;
            --ty: ${(Math.random() - 0.5) * 200}px;
            animation: particleFloat ${Math.random() * 10 + 10}s linear infinite;
            animation-delay: ${Math.random() * -10}s;
        `;
        hero.appendChild(particle);
    }
}
