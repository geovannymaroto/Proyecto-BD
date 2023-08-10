/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author LuisK
 */
public class estadoGeneral {
    Connection con;
    Conexion cn = new Conexion();

    public void generarVistaInv(){
        String sql = "SELECT * FROM inventarioEG";
        con = cn.getConnection();
        try {
            Statement stmt = con.createStatement();
            stmt.executeQuery(sql);
        } catch (SQLException ex) {
            Logger.getLogger(estadoGeneral.class.getName()).log(Level.SEVERE, null, ex);
        }
    
}
}
