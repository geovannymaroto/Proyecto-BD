package modelo;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;

public class Conexion1 {

        String url = "jdbc:oracle:thin:@localhost:1521:orcl";
        String user = "DBAPROY";
        String pass = "dba24680";
        Connection con;
        
        public Connection conectar() throws ClassNotFoundException{
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(url, user, pass);
            //Statement stmt = conn.createStatement();
        } catch (SQLException ex) {
            System.out.println("Error en la conexion" + ex.getLocalizedMessage());
        }
        return con;
    }

    }