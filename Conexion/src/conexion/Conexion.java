/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package conexion;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.ResultSet;
/**
 *
 * @author 50660
 */
public class Conexion {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
    String url="jdbc:oracle:thin:@localhost:1521:orcl";
        String user="DBAPROY";
        String pass = "dba24680";
        String sql = "select * from CLIENTES";
        
        Connection conn;
        try{
        
            conn = DriverManager.getConnection(url,user,pass);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
          
            
            System.out.println("conexion exitosa");
           while(rs.next()){
          //  int ced_cliente = rs.getInt(1);
           String NOMBRE_PROVEDOR = rs.getNString(2);
//            String nombre = rs.getNString(3);
            
           
            
            System.out.println("El codigo del empleado es:" + NOMBRE_PROVEDOR  );

            }
            
            conn.close();
        }catch(SQLException ex){
            System.out.println("Error en la conexion" + ex.getLocalizedMessage());
        }
        
        
    }
  
    }
    

