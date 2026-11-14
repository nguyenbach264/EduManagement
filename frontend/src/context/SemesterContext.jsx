import React, { createContext, useContext, useEffect, useState } from 'react';
import { commonApi } from '../api/services';
import { useAuth } from './AuthContext';

const SemesterContext = createContext(undefined);

export const SemesterProvider = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const [semesters, setSemesters] = useState([]);
  const [selectedSemesterId, setSelectedSemesterId] = useState(undefined);

  const reloadSemesters = async () => {
    if (!isAuthenticated) {
      setSemesters([]);
      return;
    }
    try {
      const list = await commonApi.getSemesters();
      setSemesters(list);
      if (list.length > 0) {
        const openSem = list.find((s) => s.registerOpen);
        setSelectedSemesterId((prev) =>
          prev && list.some((s) => s.id === prev) ? prev : openSem?.id ?? list[0].id
        );
      }
    } catch {
      // handled silently
    }
  };

  useEffect(() => {
    reloadSemesters();
  }, [isAuthenticated]);

  const selectedSemester = semesters.find((s) => s.id === selectedSemesterId);

  return (
    <SemesterContext.Provider
      value={{
        semesters,
        selectedSemesterId,
        selectedSemester,
        setSelectedSemesterId,
        reloadSemesters,
      }}
    >
      {children}
    </SemesterContext.Provider>
  );
};

export function useSemester() {
  const ctx = useContext(SemesterContext);
  if (!ctx) throw new Error('useSemester must be used inside SemesterProvider');
  return ctx;
}
