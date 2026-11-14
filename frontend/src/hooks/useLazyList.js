import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

/**
 * Hook for progressive lazy loading on scroll (Infinite scroll slice).
 * - "Kéo UI đến đâu thì hiển thị đến đó"
 * - Automatically detects table container scroll and window scroll
 * - Resets slice count when data or filter criteria changes
 *
 * @param {Array} allItems - The full dataset array (e.g. 3000 students or 200 courses)
 * @param {Object} options - Configuration options: { initialCount: 40, pageSize: 40, thresholdPx: 160 }
 */
export function useLazyList(allItems = [], options = {}) {
  const { initialCount = 40, pageSize = 40, thresholdPx = 180 } = options;
  const [visibleCount, setVisibleCount] = useState(initialCount);
  const containerRef = useRef(null);

  // Reset to initial slice whenever data array reference or size changes significantly
  useEffect(() => {
    setVisibleCount(initialCount);
  }, [allItems?.length, initialCount]);

  const totalCount = allItems?.length ?? 0;
  const hasMore = visibleCount < totalCount;

  const loadMore = useCallback(() => {
    if (visibleCount < totalCount) {
      setVisibleCount((prev) => Math.min(prev + pageSize, totalCount));
    }
  }, [visibleCount, totalCount, pageSize]);

  // Handle scroll on an element (e.g. .ant-table-body or scrollable div)
  const handleScroll = useCallback(
    (e) => {
      const target = e?.currentTarget || e?.target;
      if (!target) return;
      const { scrollTop, scrollHeight, clientHeight } = target;
      if (scrollHeight - scrollTop - clientHeight <= thresholdPx) {
        loadMore();
      }
    },
    [thresholdPx, loadMore]
  );

  // Also listen for window scroll when table is full page height without internal scroll.y
  useEffect(() => {
    if (!hasMore) return;

    const onWindowScroll = () => {
      const scrollY = window.scrollY || window.pageYOffset;
      const windowHeight = window.innerHeight;
      const docHeight = document.documentElement.scrollHeight;

      if (docHeight - (scrollY + windowHeight) <= thresholdPx + 100) {
        loadMore();
      }
    };

    window.addEventListener('scroll', onWindowScroll, { passive: true });
    return () => window.removeEventListener('scroll', onWindowScroll);
  }, [hasMore, thresholdPx, loadMore]);

  // Hook up container ref for internal scrolling
  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    // Look for .ant-table-body inside container if it exists
    const scrollTarget = el.querySelector('.ant-table-body') || el;
    scrollTarget.addEventListener('scroll', handleScroll, { passive: true });

    return () => {
      scrollTarget.removeEventListener('scroll', handleScroll);
    };
  }, [handleScroll]);

  const visibleData = useMemo(() => {
    if (!allItems || !allItems.length) return [];
    return allItems.slice(0, visibleCount);
  }, [allItems, visibleCount]);

  return {
    visibleData,
    visibleCount: Math.min(visibleCount, totalCount),
    totalCount,
    hasMore,
    loadMore,
    containerRef,
    handleScroll,
  };
}
