package eko_public;

import java.sql.Connection;
import java.sql.DriverManager;
import javax.swing.JOptionPane;

public class Conexion {
//    public static Connection getConexion(){
    public static Connection getConexion(){
        
    Connection con = null;
    String url = "jdbc:oracle:thin:@localhost:1521:orcl";
    String user = "DBAPROY";
    String pass = "dba24680";
    
//    public Connection conectar() throws ClassNotFoundException{
        try{
            con = DriverManager.getConnection(url, user, pass); 
            JOptionPane.showMessageDialog(null,"Se conecto correctamente a la Base de Datos ");
        } catch(Exception e){
            JOptionPane.showMessageDialog(null,"Error al conectar a la base de datos, error: "+e.toString());
            System.out.println(e.toString());
//            return null;
        }
        return con;
}
}

