package murach.db;

import java.util.List;

public interface DAO<T> {
    T get(String code) throws DAOException;
    List<T> getAll() throws DAOException;
    boolean add(T t) throws DAOException;
    boolean update(T t) throws DAOException;
    boolean delete(T t) throws DAOException;
}