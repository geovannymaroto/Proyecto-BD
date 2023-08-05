/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author 50660
 */
public class UsuarioDAO implements validar {

    Connection con;
    Conexion cn = new Conexion();
    PreparedStatement ps;
    ResultSet rs;
    int r = 0;

    @Override
    public int validar(Usuario user) {
        String sql = "select * from usuario where CED=? and CONTRASENHA=?";
        try {
            con = cn.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, user.getCedula());
            ps.setString(2, user.getContrasena());
            rs = ps.executeQuery();

            while (rs.next()) {
                r = r + 1;
                user.setCedula(rs.getInt("cedula"));
                user.setContrasena(rs.getString("contrasena"));

            }
            if(r==1){
               return 1;
            
            }else
                return 0;
            
        } catch (Exception e) {
            return 0;
        }

    }

    
}
