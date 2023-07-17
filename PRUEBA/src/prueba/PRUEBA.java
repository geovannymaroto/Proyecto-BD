/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package prueba;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.ResultSet;
/**
 *
 * @author 50660
 */
public class PRUEBA {
 public static void main(String[] args) {
        String url="jdbc:oracle:thin:@localhost:1521:orcl";
        String user="hr";
        String pass = "12345";
        String sql = "select * from employees ";
        
        Connection conn;
        try{
        
            conn = DriverManager.getConnection(url,user,pass);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
          
           while(rs.next()){
            int empId = rs.getInt(1);
            String nombre = rs.getNString(2);
            String apellido = rs.getNString(3);
            
            System.out.println("El codigo del empleado es:" + empId + " " + "nombre: " + nombre+ " " + "Apellido: " + apellido );
            
                    
            
     
            }
            
            conn.close();
        }catch(SQLException ex){
            System.out.println("Error en la conexion" + ex.getLocalizedMessage());
        }
        
        
    }
  

 
 
 
 }  
 
 

