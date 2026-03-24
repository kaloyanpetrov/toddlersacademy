(function () {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }

    var sections = document.querySelectorAll('main section');
    if (!sections.length) {
        return;
    }

    function isInitiallyVisible(section) {
        var rect = section.getBoundingClientRect();
        var vh = window.innerHeight || document.documentElement.clientHeight;
        return rect.top < vh * 0.98 && rect.bottom > 0;
    }

    sections.forEach(function (section) {
        if (isInitiallyVisible(section)) {
            section.classList.add('section-in-view');
        }
    });

    document.body.classList.add('sections-animate');

    var observer = new IntersectionObserver(
        function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('section-in-view');
                    observer.unobserve(entry.target);
                }
            });
        },
        {
            threshold: 0.08,
            rootMargin: '0px 0px 12% 0px'
        }
    );

    sections.forEach(function (section, index) {
        section.style.transitionDelay = Math.min(index * 0.05, 0.25) + 's';
        if (!section.classList.contains('section-in-view')) {
            observer.observe(section);
        }
    });
})();
