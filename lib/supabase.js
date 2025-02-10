import AsyncStorage from "@react-native-async-storage/async-storage";
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "https://doeuabhnhbeqreaugcnl.supabase.co";
const supabaseAnonKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvZXVhYmhuaGJlcXJlYXVnY25sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg5NTY0NDQsImV4cCI6MjA1NDUzMjQ0NH0.ddZPtd_3aBwbETF9sxW4pY754cIqF6FFJv93gIx6usY";

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
