package murach.db;

/* 
 * This is just a wrapper class so we can throw a common exception for
 * the UI to catch without tightly coupling the UI to the database layer.
 */
@SuppressWarnings("serial")
public class DAOException extends Exception {
    DAOException() {}
    
    DAOException(Exception e) {
        super(e);
    }
}