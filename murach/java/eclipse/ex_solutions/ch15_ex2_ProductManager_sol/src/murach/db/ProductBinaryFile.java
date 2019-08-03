package murach.db;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import murach.business.Product;

public final class ProductBinaryFile implements DAO<Product> {
    private List<Product> products = null;
    private Path productsPath = null;
    private File productsFile = null;

    public ProductBinaryFile() {
        productsPath = Paths.get("products.bin");
        try {
            if (Files.notExists(productsPath)) {
                System.out.println("Data file not found.");
                System.out.println("Creating file: " + 
                        productsPath.toAbsolutePath() + "\n");
                Files.createFile(productsPath);
            }
        } catch (IOException e) {
            System.out.println(e);
        }
        productsFile = productsPath.toFile();
        products = this.getAll();
    }

    @Override
    public List<Product> getAll() {
        // if the products file has already been read, don't read it again
        if (products != null) {
            return products;
        }

        products = new ArrayList<>();
        if (Files.exists(productsPath)) {
            try (DataInputStream in = new DataInputStream(
                     new BufferedInputStream(
                     new FileInputStream(productsFile)))) {

                // read products from file into array list
                while (in.available() > 0) {
                    // read product data from a file
                    String code = in.readUTF();
                    String description = in.readUTF();
                    double price = in.readDouble();

                    Product p = new Product(code, description, price);
                    products.add(p);
                }
            } catch (IOException e) {
                System.out.println(e);
                return null;
            }
        } else {
            System.out.println(
                    productsPath.toAbsolutePath() + " doesn't exist.");
            return null;            
        }
        return products;
    }

    @Override
    public Product get(String code) {
        for (Product p : products) {
            if (p.getCode().equals(code)) {
                return p;
            }
        }
        return null;
    }

    private boolean saveAll() {
        try (DataOutputStream out = new DataOutputStream(
                       new BufferedOutputStream(
                       new FileOutputStream(productsFile)))) {

            // write all products in the array list
            // to the file
            for (Product p : products) {
                out.writeUTF(p.getCode());
                out.writeUTF(p.getDescription());
                out.writeDouble(p.getPrice());
            }
            return true;            
        } catch (IOException e) {
            System.out.println(e);
            return false;
        }
    }
    
    @Override
    public boolean add(Product p) {
        products.add(p);
        return this.saveAll();
    }

    @Override
    public boolean delete(Product p) {
        products.remove(p);
        return this.saveAll();
    }

    @Override
    public boolean update(Product newProduct) {
        // get the old product and remove it
        Product oldProduct = this.get(newProduct.getCode());
        int i = products.indexOf(oldProduct);
        products.remove(i);

        // add the updated product
        products.add(i, newProduct);

        return this.saveAll();
    }
}