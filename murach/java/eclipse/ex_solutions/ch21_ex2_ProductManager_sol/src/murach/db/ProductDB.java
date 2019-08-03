package murach.db;

import murach.business.Product;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductDB implements DAO<Product> {
    
    private Connection connection;
    
    public ProductDB() {
        try {
            String dbUrl = "jdbc:sqlite:products.sqlite";
            connection = DriverManager.getConnection(dbUrl);        
        } catch (SQLException e) {
            System.err.println(e);
        }        
    }
    
    public void closeConnection() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
            System.err.println(e);
        }
    }
    
    private Product getProductFromRow(ResultSet rs) throws SQLException {
        String code = rs.getString(1);
        String description = rs.getString(2);
        double price = rs.getDouble(3);

        Product product = new Product(code, description, price);        
        return product;
    }

    @Override
    public List<Product> getAll() {
        String sql = "SELECT ProductCode, Description, Price "
                   + "FROM Products ORDER BY ProductCode ASC";
        List<Product> products = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = getProductFromRow(rs);
                products.add(p);
            }
            return products;
        } catch (SQLException e) {
            System.err.println(e);
            return null;
        }
    }

    @Override
    public Product get(String code) {
        String sql = "SELECT ProductCode, Description, Price "
                   + "FROM Products "
                   + "WHERE ProductCode = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Product p = getProductFromRow(rs);
                rs.close();
                return p;
            } else {
                rs.close();
                return null;
            }
        } catch (SQLException e) {
            System.err.println(e);
            return null;
        }
    }

    @Override
    public boolean add(Product p) {
        String sql = "INSERT INTO Products (ProductCode, Description, Price) "
                   + "VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, p.getCode());
            ps.setString(2, p.getDescription());
            ps.setDouble(3, p.getPrice());
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println(e);
            return false;
        }
    }

    @Override
    public boolean delete(Product p) {
        String sql = "DELETE FROM Products "
                   + "WHERE ProductCode = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, p.getCode());
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println(e);
            return false;
        }
    }

    @Override
    public boolean update(Product p) {
        String sql = "UPDATE Products SET "
                   + "  Description = ?, "
                   + "  Price = ? "
                   + "WHERE ProductCode = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, p.getDescription());
            ps.setDouble(2, p.getPrice());
            ps.setString(3, p.getCode());
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println(e);
            return false;
        }
    }
}