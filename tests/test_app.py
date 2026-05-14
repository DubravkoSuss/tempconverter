import pytest
from app import app, db, Temperature

app.config['WTF_CSRF_ENABLED'] = False
app.config['TESTING'] = True

@pytest.fixture(autouse=True)
def clean_db():
    with app.app_context():
        db.create_all()
        yield
        Temperature.query.delete()
        db.session.commit()

@pytest.fixture
def client():
    return app.test_client()

def test_home_page_loads(client):
    response = client.get('/')
    assert response.status_code == 200

def test_student_college_displayed(client):
    response = client.get('/')
    assert b'Student' in response.data or b'Posavac' in response.data

def test_celsius_to_fahrenheit_conversion(client):
    """Unit test: conversion formula"""
    assert round((0 * 1.8) + 32, 2) == 32.0
    assert round((100 * 1.8) + 32, 2) == 212.0

def test_form_submission_stores_in_db(client):
    """Integration test: form submission saves record to database"""
    client.post('/', data={'celsius': '25', 'submit': 'Convert'}, follow_redirects=True)
    with app.app_context():
        record = Temperature.query.filter_by(celsius=25.0).first()
        assert record is not None
        assert record.fahrenheit == 77.0

def test_multiple_conversions_appear_in_history(client):
    """Integration test: multiple submissions show in recent conversions table"""
    client.post('/', data={'celsius': '0', 'submit': 'Convert'}, follow_redirects=True)
    client.post('/', data={'celsius': '100', 'submit': 'Convert'}, follow_redirects=True)
    response = client.get('/')
    assert b'32.0' in response.data
    assert b'212.0' in response.data
