-- Enable the avatars storage bucket (idempotent)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Allow authenticated users to manage their own avatar folder.
-- Path format: <user_id>/avatar.jpg
-- auth.uid()::text returns lowercase UUID, so upload paths must also be lowercase.
create policy "Users can manage their own avatar"
  on storage.objects
  for all
  to authenticated
  using  ((storage.foldername(name))[1] = auth.uid()::text)
  with check ((storage.foldername(name))[1] = auth.uid()::text);
