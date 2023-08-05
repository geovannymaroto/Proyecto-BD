/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 *
 * @author 50660
 */
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
//import java.sql.Statement;
//import java.sql.ResultSet;

/**
 *
 * @author 50660
 */
public class Conexion {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        String url = "jdbc:oracle:thin:@localhost:1521:orcl";
        String user = "DBAPROY";
        String pass = "dba24680";

        Connection conn;
        try {

            conn = DriverManager.getConnection(url, user, pass);
            //Statement stmt = conn.createStatement();

            System.out.println("conexion exitosa");

            conn.close();
        } catch (SQLException ex) {
            System.out.println("Error en la conexion" + ex.getLocalizedMessage());
        }

    }

    Connection getConnection() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

}
