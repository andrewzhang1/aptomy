import java.sql.*;


class MysqlCon {
    public static void main(String args[]) {
        try {
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection("jdbc:mysql://vmlxu2:3306/bank", "root", "password");
//here sonoo is the database name, root is the username and root is the password
            Statement stmt = con.createStatement();

            ResultSet rs = stmt.executeQuery("select * from business");

            while (rs.next())
                System.out.println(rs.getInt(1) + "  " + rs.getString(2) + "  " + rs.getString(3));

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }
}


/*
Connection String: root@vmlxu2:3306
JDBC string: jdbc:mysql://vmlxu2:3306/?user=root
*/
