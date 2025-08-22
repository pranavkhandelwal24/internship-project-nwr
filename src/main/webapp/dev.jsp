<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Developers</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --carousel-radius: 380px;
      --carousel-height: 280px;
      --card-width: 220px;
      --card-height: 320px;
    }

    body {
      font-family: 'Inter', sans-serif;
      background-color: #0f172a;
      color: #f8fafc;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
    }

    .main-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 2rem 1rem;
      perspective: 1200px;
    }

    .carousel-wrapper {
      position: relative;
      width: 100%;
      max-width: 1000px;
      height: var(--carousel-height);
      margin: 3rem 0;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .carousel-stage {
      position: relative;
      width: 100%;
      height: 100%;
      transform-style: preserve-3d;
      cursor: grab;
      user-select: none;
    }

    .team-member {
      position: absolute;
      width: var(--card-width);
      height: var(--card-height);
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      transform-origin: center center;
      transition: transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
      backface-visibility: hidden;
      overflow: visible;
      background: transparent;
    }

    .team-member img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.7));
      pointer-events: none;
      user-select: none;
      -webkit-user-drag: none;
      draggable: false;
    }

    .details-panel {
      background: rgba(15, 23, 42, 0.9);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(100, 116, 139, 0.3);
      border-radius: 1rem;
      box-shadow: 0 0 30px rgba(59, 130, 246, 0.3);
      width: 100%;
      max-width: 800px;
      padding: 2rem;
      margin: 2rem auto;
      transition: all 0.5s ease;
    }

    .member-name {
      background: linear-gradient(90deg, #3b82f6, #6366f1);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }

    @media (max-width: 1024px) {
      :root {
        --carousel-radius: 320px;
        --card-width: 200px;
        --card-height: 280px;
      }
    }

    @media (max-width: 768px) {
      :root {
        --carousel-radius: 280px;
        --carousel-height: 240px;
        --card-width: 160px;
        --card-height: 240px;
      }
    }

    @media (max-width: 480px) {
      :root {
        --carousel-radius: 240px;
        --carousel-height: 200px;
        --card-width: 140px;
        --card-height: 200px;
      }

      .details-panel {
        padding: 1.5rem;
      }
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .animate-fadein {
      animation: fadeIn 0.6s ease-out forwards;
    }
  </style>
</head>
<body>
  <div class="main-container">
    <h1 class="text-4xl md:text-5xl font-bold mb-8 text-center">Developers</h1>

    <div class="carousel-wrapper">
      <div id="carousel" class="carousel-stage"></div>
    </div>

    <div id="details" class="details-panel animate-fadein"></div>
  </div>

  <script>
    const teamMembers = [
      {
        id: 1,
        name: 'Pranav Khandelwal',
        role: 'CSE-AI',
        bio: '2023pcecapranav034@poornima.org',
        imageUrl: 'assets/pik.png',
      },
      {
        id: 2,
        name: 'Ishita Jain',
        role: 'CSE',
        bio: '2023pcecsishita067@poornima.org',
        imageUrl: 'assets/k.png',
      },
      {
        id: 3,
        name: 'Mitanshu Kumar Mehta',
        role: 'CSE-AI',
        bio: '2023pcecamitanshu026@poornima.org',
        imageUrl: 'assets/mi.png',
      },
      {
        id: 4,
        name: 'AI',
        role: 'Master',
        bio: '...',
        imageUrl: 'assets/baymax.png',
      },
      
    ];

    const carousel = document.getElementById('carousel');
    const detailsPanel = document.getElementById('details');

    let currentIndex = 0;
    let autoRotateInterval;
    const rotationDelay = 8000;
    let isDragging = false;
    let startX, currentAngle = 0, targetAngle = 0;
    let animationId;

    function initCarousel() {
      carousel.innerHTML = '';
      teamMembers.forEach((member, index) => {
        const memberElement = document.createElement('div');
        memberElement.className = 'team-member';
        memberElement.id = `member-${member.id}`;

        const img = document.createElement('img');
        img.src = member.imageUrl;
        img.alt = member.name;
        img.onerror = () => { img.src = 'https://via.placeholder.com/300x400?text=Team+Member'; };
        img.draggable = false;

        memberElement.appendChild(img);
        memberElement.addEventListener('click', () => handleMemberClick(index));
        carousel.appendChild(memberElement);
      });

      updateCarousel();
      updateDetails();
      startAutoRotation();
      setupEventListeners();
    }

    function updateCarousel() {
      const memberCount = teamMembers.length;
      const angleStep = (2 * Math.PI) / memberCount;
      const carouselRadius = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--carousel-radius'));

      teamMembers.forEach((member, index) => {
        const element = document.getElementById(`member-${member.id}`);
        const memberAngle = index * angleStep + currentAngle;

        const distanceFactor = Math.cos(memberAngle);
        const scale = 0.7 + ((distanceFactor + 1) / 2) * 0.5;

        element.style.transform = `
          translate(-50%, -50%)
          rotateY(${memberAngle}rad)
          translateZ(${carouselRadius}px)
          scale(${scale})
        `;

        element.style.zIndex = Math.floor(distanceFactor * 100);
      });
    }

    function updateDetails() {
      const m = teamMembers[currentIndex];
      detailsPanel.innerHTML = `
        <h2 class="text-3xl font-bold mb-2 member-name">${m.name}</h2>
        <h3 class="text-xl text-slate-300 mb-4">${m.role}</h3>
        <p class="text-slate-200 leading-relaxed">${m.bio}</p>
      `;
      detailsPanel.classList.add('animate-fadein');
      setTimeout(() => detailsPanel.classList.remove('animate-fadein'), 600);
    }

    function handleMemberClick(idx) {
      if (!isDragging) goToIndex(idx);
    }

    function goToIndex(idx) {
      currentIndex = (idx + teamMembers.length) % teamMembers.length;
      const step = (2 * Math.PI) / teamMembers.length;
      targetAngle = -currentIndex * step;
      animate(); updateDetails(); resetAutoRotation();
    }

    function animate() {
      if (animationId) cancelAnimationFrame(animationId);
      const frame = () => {
        currentAngle += (targetAngle - currentAngle) * 0.15;
        if (Math.abs(targetAngle - currentAngle) > 0.001) {
          updateCarousel();
          animationId = requestAnimationFrame(frame);
        } else {
          currentAngle = targetAngle;
          updateCarousel();
        }
      };
      animationId = requestAnimationFrame(frame);
    }

    function startAutoRotation() {
      autoRotateInterval = setInterval(() => goToIndex(currentIndex + 1), rotationDelay);
    }

    function resetAutoRotation() {
      clearInterval(autoRotateInterval);
      startAutoRotation();
    }

    function handleDragStart(e) {
      isDragging = true;
      startX = e.type.includes('mouse') ? e.pageX : e.touches[0].clientX;
      carousel.style.cursor = 'grabbing';
      cancelAnimationFrame(animationId);
      clearInterval(autoRotateInterval);
    }

    function handleDragMove(e) {
      if (!isDragging) return;
      e.preventDefault();
      const currentX = e.type.includes('mouse') ? e.pageX : e.touches[0].clientX;
      const deltaX = startX - currentX;
      currentAngle = targetAngle - (deltaX * 0.005);
      updateCarousel();
    }

    function handleDragEnd() {
      if (!isDragging) return;
      isDragging = false;
      carousel.style.cursor = 'grab';

      const count = teamMembers.length;
      const step = (2 * Math.PI) / count;
      const norm = ((-currentAngle % (2 * Math.PI)) + (2 * Math.PI)) % (2 * Math.PI);

      let best = 0, minDiff = Infinity;
      for (let i = 0; i < count; i++) {
        const ideal = i * step;
        const diff = Math.abs(norm - ideal);
        const sd = Math.min(diff, 2 * Math.PI - diff);
        if (sd < minDiff) { minDiff = sd; best = i; }
      }
      goToIndex(best);
    }

    function setupEventListeners() {
      carousel.addEventListener('mousedown', handleDragStart);
      document.addEventListener('mousemove', handleDragMove);
      document.addEventListener('mouseup', handleDragEnd);
      carousel.addEventListener('touchstart', handleDragStart, { passive: false });
      document.addEventListener('touchmove', handleDragMove, { passive: false });
      document.addEventListener('touchend', handleDragEnd);
      document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft') goToIndex(currentIndex - 1);
        else if (e.key === 'ArrowRight') goToIndex(currentIndex + 1);
        resetAutoRotation();
      });
      window.addEventListener('resize', updateCarousel);
    }

    document.addEventListener('DOMContentLoaded', initCarousel);
  </script>
</body>
</html>
