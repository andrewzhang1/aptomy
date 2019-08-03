package murach.db;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import murach.business.Product;

public final class ProductTextFile implements DAO<Product> {
    private List<Product> products = null;
    private Path productsPath = null;
    private File productsFile = null;
    private final String FIELD_SEP = "\t";

    public ProductTextFile() throws DAOException {
        productsPath = Paths.get("products.txt");
        productsFile = productsPath.toFile();
        products = this.getAll();
    }

    @Override
    public List<Product> getAll() throws DAOException {
        // if the products file has already been read, don't read it again
        if (products != null) {
            return products;
        }

        products = new ArrayList<>();
        try (BufferedReader in = new BufferedReader(
                                 new FileReader(productsFile))) {

            // read products from file into array list
            String line = in.readLine();
            while (line != null) {
                String[] fields = line.split(FIELD_SEP);
                String code = fields[0];
                String description = fields[1];
                String price = fields[2];

                Product p = new Product(
                        code, description, Double.parseDouble(price));
                products.add(p);

                line = in.readLine();
            }
        } catch (IOException e) {
            throw new DAOException(e);
        }
        return products;
    }

    @Override
    public Product get(String code) throws DAOException {
        for (Product p : products) {
            if (p.getCode().equals(code)) {
                return p;
            }
        }
        return null;
    }

    @Override
    public boolean add(Product p) throws DAOException {
        products.add(p);
        return this.saveAll();
    }

    @Override
    public boolean delete(Product p) throws DAOException {
        products.remove(p);
        return this.saveAll();
    }

    @Override
    public boolean update(Product newProduct) throws DAOException {
        // get the old product and remove it
        Product oldProduct = this.get(newProduct.getCode());
        int i = products.indexOf(oldProduct);
        products.remove(i);

        // add the updated product
        products.add(i, newProduct);

        return this.saveAll();
    }

    private boolean saveAll() throws DAOException {
        try (PrintWriter out = new PrintWriter(
                               new BufferedWriter(
                               new FileWriter(productsFile)))) {

            // write all products in the array list
            // to the file
            for (Product p : products) {
                out.print(p.getCode() + FIELD_SEP);
                out.print(p.getDescription() + FIELD_SEP);
                out.println(p.getPrice());
            }
            return true;            
        } catch (IOException e) {
            throw new DAOException(e);
        }
    }
}