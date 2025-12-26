SELECT 
  p.proname as function_name, 
  pg_get_functiondef(p.oid) as function_definition 
FROM 
  pg_proc p
JOIN 
  pg_namespace n ON p.pronamespace = n.oid
WHERE 
  n.nspname = 'public' -- بنفلتر عشان نجيب بس الدوال بتاعتك مش دوال السيستم
ORDER BY 
  p.proname;

